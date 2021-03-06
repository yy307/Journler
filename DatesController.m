
/*
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 * Neither the name of the author nor the names of its contributors may be used to endorse or
 promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Basically, you can use the code in your free, commercial, private and public projects
// as long as you include the above notice and attribute the code to Philip Dow / Sprouted
// If you use this code in an app send me a note. I'd love to know how the code is used.

// Please also note that this copyright does not supersede any other copyrights applicable to
// open source code used herein. While explicit credit has been given in the Journler about box,
// it may be lacking in some instances in the source code. I will remedy this in future commits,
// and if you notice any please point them out.

#import "DatesController.h"
#import "Definitions.h"

#import "Calendar.h"
#import "JournlerEntry.h"

@implementation DatesController

- (void) awakeFromNib
{
	
	//prep the dates array controller
	NSSortDescriptor *dateDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateCreatedInt" ascending:NO] autorelease];
	[self setSortDescriptors:[NSArray arrayWithObject:dateDescriptor]];

	//[self bind:@"selectedDate" toObject:calendar withKeyPath:@"selectedDate" options:nil];
	//[calendar bind:@"content" toObject:self withKeyPath:@"arrangedObjects" options:nil];
}

- (void) dealloc
{
	#ifdef __DEBUG__
	NSLog(@"%s",__PRETTY_FUNCTION__);
	#endif
	
	[datePredicate release];
	[selectedDate release];
	[calendar release];
	
	[super dealloc];
}

#pragma mark -

- (id) delegate 
{ 
	return delegate; 
}

- (void) setDelegate:(id)anObject 
{
	delegate = anObject;
}

- (NSDate*) selectedDate 
{
	return selectedDate;
}

- (void) setSelectedDate:(NSDate*)aDate 
{	
	if ( selectedDate != aDate ) 
	{
		if ( delegate != nil && [delegate respondsToSelector:@selector(datesController:willChangeDate:)] )
			[delegate datesController:self willChangeDate:selectedDate];
		
		[selectedDate release];
		selectedDate = [aDate retain];
		
		[self updateSelectedObjects:self];
		
		if ( delegate != nil && [delegate respondsToSelector:@selector(datesController:didChangeDate:)] )
			[delegate datesController:self didChangeDate:selectedDate];
	}
}

- (NSPredicate*) datePredicate 
{
	return datePredicate;
}

- (void) setDatePredicate:(NSPredicate*)aPredicate 
{
	if ( datePredicate != aPredicate ) {
		[datePredicate release];
		datePredicate = [aPredicate retain];
	}
}

- (Calendar*) calendar
{
	return calendar;
}

- (void) setCalendar:(Calendar*)aCalendar
{
	if ( calendar != aCalendar )
	{
		[calendar release];
		calendar = [aCalendar retain];
	}
}

#pragma mark -

- (void) updateSelectedObjects:(id)sender 
{
	NSInteger i;
	NSArray *objects = [self arrangedObjects];
	NSMutableArray *newSelection = [NSMutableArray array];
	NSInteger dateInt = [[selectedDate descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil] integerValue];
	
	for ( i = 0; i < CFArrayGetCount((CFArrayRef)objects); i++ )
	{
		JournlerEntry *anEntry = (id)CFArrayGetValueAtIndex((CFArrayRef)objects,i);
		if ( [anEntry dateCreatedInt] == dateInt && ![[anEntry valueForKey:@"markedForTrash"] boolValue] )
			[newSelection addObject:anEntry];
	}
	
	[self setSelectedObjects:newSelection];
}

- (void)setContent:(id)content
{
	[super setContent:content];
	[self updateSelectedObjects:self];
}

@end
